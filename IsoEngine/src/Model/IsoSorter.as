package Model
{
	/**
	 * Objeto auxiliar para ayudar al ordenamiento de IsoObjs en el mundo isometrico, según su profundidad
	 */
	public final class IsoSorter
	{
		public function IsoSorter()
		{
		}

		public function Sort(isoComps : Array) : Array
		{
			mIsoComps = isoComps;
			
			if (mIsoComps.length == 0)
				return mIsoComps;
			
			mIsoComps.sortOn(["FrontRigthZ", "FrontRigthX"], Array.NUMERIC | Array.DESCENDING );			

			var sortedSolution : Array = new Array();
			for (var c : int = 0; c < mIsoComps.length; c++)
			{
				// Procesamos todos los "padres" que queden disjuntos
				if (!mIsoComps[c].SortingProcessed)
					ProcessNode(c, sortedSolution);
			}
			
			mIsoComps = null;
			
			for (c = 0; c < sortedSolution.length; c++)
			{
				sortedSolution[c].SortingProcessed = false;
			}
			
			return sortedSolution;
		}

		private function ProcessNode(idxNode : int, ret : Array) : void
		{
			var currNodeBounds : IsoBounds = mIsoComps[idxNode].Bounds; 
			
			// Primero los que están a la derecha del nodo
			for (var c : int = idxNode+1; c < mIsoComps.length; c++)
			{
				if (mIsoComps[c].SortingProcessed)
					continue;

				var nextNodeBounds : IsoBounds = mIsoComps[c].Bounds;
				
				// Si es disjunto, se acabó
				if (nextNodeBounds.Front <= currNodeBounds.Back)
					break;
				
				if (nextNodeBounds.Left >= currNodeBounds.Right)
					ProcessNode(c, ret);
			}
			
			// Render del nodo
			ret.push(mIsoComps[idxNode]);
			mIsoComps[idxNode].SortingProcessed = true;
			
			// Ahora los que están a la izquierda
			for (c = idxNode+1; c < mIsoComps.length; c++)
			{
				if (mIsoComps[c].SortingProcessed)
					continue;

				nextNodeBounds = mIsoComps[c].Bounds;
				
				if (nextNodeBounds.Front <= currNodeBounds.Back)
					break;
				
				if (nextNodeBounds.Right >= currNodeBounds.Right)
					ProcessNode(c, ret);				
			}
		}
		
		private var mIsoComps : Array;
	}
}